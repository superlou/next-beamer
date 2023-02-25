# Homemade python-dotenv to avoid needing to PIP install on targets
import os
import configparser

def load_dotenv():
    if os.path.isfile(".env"):
        config = configparser.ConfigParser()
        config.optionxform = lambda option: option  # Don't make lowercase
        config.read(".env")

        for section in config.sections():
            for variable in config[section]:
                os.environ[variable] = config[section][variable]
