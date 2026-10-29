#!/usr/bin/python3
# type: ignore
# Purpose: Return the md5/sha256 of a file or input string
# Name: checksum.py
# Modified on: mar 12 sep 2023 16:07:38 CEST
##############################################################################
""" Return the hash of a file or input string """

import click
import hashlib


class CheckSum:
    """Return the md5/sha256 of a string or input file"""

    def __init__(self, hash_type, data):
        """Initialize instance variables"""
        self.md5 = False
        self.sha256 = False
        self.hash_type = None
        self.data = data.encode() if data else None

        self.process_args(hash_type)

    def process_args(self, hash_type):
        """Process arguments"""

        if hash_type == "md5":
            self.md5 = True
            self.hash_type = "md5"
        elif hash_type == "sha256":
            self.sha256 = True
            self.hash_type = "sha256"

        if self.data:
            self.print_sum(self.data)

    def checksum(self, data: bytes) -> str:
        """Perform the hash of the string or input data"""
        _checksum = None

        if self.md5:
            md5_hash = hashlib.md5()
            md5_hash.update(data)
            _checksum = md5_hash.hexdigest()

        elif self.sha256:
            sha256_hash = hashlib.sha256()
            sha256_hash.update(data)
            _checksum = sha256_hash.hexdigest()

        return _checksum

    def print_sum(self, data: bytes) -> None:
        """Print the hash type"""
        if data:
            print(f"{self.checksum(data)}  ({self.hash_type})")
        else:
            print("[-] No input data provided.")


@click.command(epilog="Usage: checksum.py -m -d FILE | string")
@click.option("-m", "--md5", "hash_type", flag_value="md5", help="md5 encoding")
@click.option(
    "-s", "--sha256", "hash_type", flag_value="sha256", help="sha256 encoding"
)
@click.option("-d", "--data", type=str, help="Input file or string")
def cli(hash_type, data):
    """Calculates the hash of a file or a string."""
    CheckSum(hash_type, data)


if __name__ == "__main__":
    cli()
