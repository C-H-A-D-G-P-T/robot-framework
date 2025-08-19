# 1. Choose Base Image
FROM python:3.11-slim

# 2. Set work directory within Image
WORKDIR /script

# 3. Copy requirement file into Image
COPY requirements.txt .

# 4. Run command to install dependencies within Image
RUN pip install -r requirements.txt

# 5. Copy ALL project code into Image
COPY . .

# 6. Command to run code when container started
CMD ["robot", "robot-framework-api/Test/E2E.robot"]