#!/usr/bin/env python3
"""
Generates REFERENCE.md from CSV files.
Run this script whenever you update the CSV files.

Usage: python docs/generate_reference.py
"""

import csv
import os
from datetime import datetime

DOCS_DIR = os.path.dirname(os.path.abspath(__file__))

def read_csv(filename):
    """Read a CSV file and return headers + rows."""
    filepath = os.path.join(DOCS_DIR, filename)
    with open(filepath, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        headers = next(reader)
        rows = list(reader)
    return headers, rows

def make_table(headers, rows):
    """Generate a markdown table from headers and rows."""
    lines = []
    # Header row
    lines.append('| ' + ' | '.join(headers) + ' |')
    # Separator
    lines.append('| ' + ' | '.join(['---'] * len(headers)) + ' |')
    # Data rows
    for row in rows:
        # Pad row if needed
        while len(row) < len(headers):
            row.append('')
        lines.append('| ' + ' | '.join(row) + ' |')
    return '\n'.join(lines)

def generate_markdown():
    """Generate the full REFERENCE.md content."""
    sections = []

    # Header
    sections.append("# Fish Food - Game Reference")
    sections.append("")
    sections.append(f"*Auto-generated from CSV files on {datetime.now().strftime('%Y-%m-%d %H:%M')}*")
    sections.append("")
    sections.append("---")
    sections.append("")

    # Decks
    sections.append("## Decks (Upgrade Packs)")
    sections.append("")
    sections.append("Decks determine which upgrades, weapons, and artifacts are available during a run.")
    sections.append("")
    headers, rows = read_csv('decks.csv')
    sections.append(make_table(headers, rows))
    sections.append("")

    # Meta Upgrades
    sections.append("## Meta Upgrades (Permanent)")
    sections.append("")
    sections.append("Permanent stat upgrades purchased with souls between runs.")
    sections.append("")
    headers, rows = read_csv('meta_upgrades.csv')
    sections.append(make_table(headers, rows))
    sections.append("")

    # Weapons
    sections.append("## Weapons")
    sections.append("")
    headers, rows = read_csv('weapons.csv')
    sections.append(make_table(headers, rows))
    sections.append("")

    # Artifacts
    sections.append("## Artifacts")
    sections.append("")
    sections.append("Passive items that provide stat bonuses or special effects.")
    sections.append("")
    headers, rows = read_csv('artifacts.csv')
    sections.append(make_table(headers, rows))
    sections.append("")

    # Enemies
    sections.append("## Enemies")
    sections.append("")
    headers, rows = read_csv('enemies.csv')
    sections.append(make_table(headers, rows))
    sections.append("")

    # Effects
    sections.append("## Effects")
    sections.append("")
    sections.append("Effects define mechanical behaviors that projectiles can have.")
    sections.append("")
    headers, rows = read_csv('effects.csv')
    sections.append(make_table(headers, rows))
    sections.append("")

    # Tags
    sections.append("## Tags Reference")
    sections.append("")
    sections.append("Tags are used for encounter weighting, weapon synergies, and damage bonuses.")
    sections.append("")
    headers, rows = read_csv('tags.csv')

    # Group tags by category
    categories = {}
    for row in rows:
        cat = row[0]
        if cat not in categories:
            categories[cat] = []
        categories[cat].append(row[1:])  # Skip category column

    for cat, cat_rows in categories.items():
        sections.append(f"### {cat} Tags")
        sections.append("")
        sections.append(make_table(['Name', 'ID', 'Description'], cat_rows))
        sections.append("")

    return '\n'.join(sections)

def main():
    content = generate_markdown()
    output_path = os.path.join(DOCS_DIR, 'REFERENCE.md')
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Generated {output_path}")

if __name__ == '__main__':
    main()
