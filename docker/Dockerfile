FROM python:3.9-alpine

# Set working directory
WORKDIR /app

# Copy requirements file and application script
COPY requirements.txt btc_usd_fetcher.py ./

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt && \
    rm -rf /root/.cache/pip

# Command to run your application
CMD ["python3", "btc_usd_fetcher.py"]