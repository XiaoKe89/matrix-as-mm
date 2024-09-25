import asyncio
import nio
import logging
import os

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Matrix credentials
matrix_homeserver = os.getenv('MATRIX_HOMESERVER')
matrix_user = os.getenv('MATRIX_USER')
matrix_password = os.getenv('MATRIX_PASSWORD')

# Constants
onduty_bot_user = "@ondutybot:mtrx.mil.intl"

async def detect_bridge_and_post_message(client, room):
    try:
        room_id = room.room_id
        logger.info(f"New room detected with ID: {room_id}")

        # Fetch room name or alias to detect if it's bridged from WhatsApp or Signal
        room_name_event = await client.room_get_state_event(room_id, "m.room.name")
        room_name = room_name_event.content.get("name", "")

        # Detect whether it's a WhatsApp or Signal bridge
        if 'WA' in room_name or 'WhatsApp' in room_name:
            logger.info(f"Room {room_id} detected as WhatsApp bridge.")
            await client.room_send(room_id, "m.room.message", {"msgtype": "m.text", "body": "!wa_od set-relay"})
        elif 'SIG' in room_name or 'Signal' in room_name:
            logger.info(f"Room {room_id} detected as Signal bridge.")
            await client.room_send(room_id, "m.room.message", {"msgtype": "m.text", "body": "!signal_od set-relay"})
        else:
            logger.warning(f"Could not determine bridge type for room {room_id}.")
            return

        # Invite '@ondutybot:mtrx.mil.intl' to the room
        logger.info(f"Inviting {onduty_bot_user} to room {room_id}")
        await client.room_invite(room_id, onduty_bot_user)

        # Post final message to the room
        logger.info(f"Posting '!od_bridge mmchannel' to room {room_id}")
        await client.room_send(room_id, "m.room.message", {"msgtype": "m.text", "body": "!od_bridge mmchannel"})

    except Exception as e:
        logger.error(f"Error handling room {room.room_id}: {str(e)}")

async def on_room_created(client, room):
    # Process the room creation event and detect the bridge type
    await detect_bridge_and_post_message(client, room)

async def main():
    # Create the Matrix client
    client = nio.AsyncClient(matrix_homeserver, matrix_user)

    try:
        # Login to Matrix
        response = await client.login(matrix_password)
        if isinstance(response, nio.LoginResponse):
            logger.info(f"Logged in to Matrix as {matrix_user}")
        else:
            logger.error(f"Failed to login: {response}")
            return

        # Add event callback for room creation
        client.add_event_callback(lambda room: on_room_created(client, room), nio.RoomCreateEvent)

        # Start syncing with the Matrix homeserver
        await client.sync_forever(timeout=30000)

    except Exception as e:
        logger.error(f"Error: {str(e)}")
    finally:
        await client.close()

if __name__ == "__main__":
    asyncio.get_event_loop().run_until_complete(main())
