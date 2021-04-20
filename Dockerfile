# Pull base image
FROM python:3.9.1

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /usr/src/app

# Copy project
COPY src /usr/src/app

# Install dependencies
RUN pip install -r /usr/src/app/requirements.txt

# Expose port 8000
EXPOSE 8000

# Start the web server
CMD python manage.py runserver 0.0.0.0:8000
