#!/bin/bash

# Example Usage Script for BHL Meta Service
# This script demonstrates various ways to use the meta service

echo "=== BHL Meta Service - Example Usage ==="
echo ""

# Example 1: Basic usage with a common species
echo "Example 1: Searching for 'Apis mellifera' on a BHL page"
echo "Command: ./bhl_meta_service.rb reconcile -n 'Apis mellifera' -u 'https://www.biodiversitylibrary.org/page/12345678'"
echo ""
./bhl_meta_service.rb reconcile -n "Apis mellifera" -u "https://www.biodiversitylibrary.org/page/12345678"

echo ""
echo "=================================================="
echo ""

# Example 2: Using full names
echo "Example 2: Searching for 'Homo sapiens'"
echo "Command: ./bhl_meta_service.rb reconcile --name 'Homo sapiens' --url 'https://www.biodiversitylibrary.org/page/987654'"
echo ""
./bhl_meta_service.rb reconcile --name "Homo sapiens" --url "https://www.biodiversitylibrary.org/page/987654"

echo ""
echo "=================================================="
echo ""

# Example 3: Limiting results
echo "Example 3: Limiting results to top 3"
echo "Command: ./bhl_meta_service.rb reconcile -n 'Felis catus' -u 'https://www.biodiversitylibrary.org/page/456789' --limit 3"
echo ""
./bhl_meta_service.rb reconcile -n "Felis catus" -u "https://www.biodiversitylibrary.org/page/456789" --limit 3

echo ""
echo "=================================================="
echo ""

# Example 4: Genus only
echo "Example 4: Searching with genus name only"
echo "Command: ./bhl_meta_service.rb reconcile -n 'Drosophila' -u 'https://www.biodiversitylibrary.org/page/111111'"
echo ""
./bhl_meta_service.rb reconcile -n "Drosophila" -u "https://www.biodiversitylibrary.org/page/111111"

echo ""
echo "=== Examples Complete ==="
echo ""
echo "For more information, run: ./bhl_meta_service.rb help reconcile"
