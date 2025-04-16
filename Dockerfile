# Use official Python image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy only requirements.txt first and install dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Now copy the rest of the application code
COPY . /app/

# Set environment variables
ENV MATTERMOST_URL=https://mattermost.example.com
ENV MATRIX_HOMESERVER_URL=https://matrix.example.com

# Expose the application port
EXPOSE 8080

# Command to run the app
CMD ["python", "app.py"]
