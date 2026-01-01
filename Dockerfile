FROM odoo:18

USER root

RUN apt-get update && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --break-system-packages git+https://github.com/ingadhoc/pyafipws.git

USER odoo