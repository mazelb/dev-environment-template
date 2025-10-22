FROM ubuntu:22.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    curl \
    wget \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    nano \
    vim \
    jq \
    pkg-config \
    libssl-dev \
    libffi-dev \
    libncurses-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    xz-utils \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.11
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN python3.11 -m pip install --upgrade pip setuptools wheel

# Install Python ML/AI packages
RUN pip install --no-cache-dir \
    numpy \
    scipy \
    pandas \
    matplotlib \
    scikit-learn \
    pytorch-lightning \
    jupyter \
    ipython \
    openai \
    anthropic \
    langchain \
    langchain-core \
    langchain-community \
    langchain-openai \
    langchain-anthropic \
    pydantic \
    pytest \
    black \
    flake8 \
    mypy \
    requests \
    python-dotenv

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN npm install -g yarn

# Install Kotlin & Java 17
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

RUN curl -s "https://get.sdkman.io" | bash && \
    bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && sdk install kotlin"

# Install additional build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    make \
    gcc-11 \
    g++-11 \
    gdb \
    valgrind \
    && rm -rf /var/lib/apt/lists/*

# Set up default gcc version
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100

# Install PostgreSQL client
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install Redis CLI
RUN apt-get update && apt-get install -y --no-install-recommends \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /workspace

# Create non-root user for development
RUN useradd -m -s /bin/bash devuser && \
    chown -R devuser:devuser /workspace

# Switch to non-root user
USER devuser

# Set up shell
ENV SHELL=/bin/bash
ENV PATH="/home/devuser/.local/bin:${PATH}"

# Default command
CMD ["/bin/bash"]