import csv
from collections import defaultdict
from pathlib import Path

# Input CSV location and output summary path.
DATA_PATH = Path(__file__).resolve().parents[1] / "data" / "aws_costs.csv"
OUTPUT_PATH = Path(__file__).resolve().parent / "analysis_summary.md"


def to_float(value):
    # Defensive parsing so bad/missing numbers do not crash the report.
    try:
        return float(value)
    except (TypeError, ValueError):
        return 0.0


def read_rows(path):
    # This argument will consider all files regardless of type
    # Normalize headers to avoid trailing whitespace causing "UNKNOWN" buckets.
    with path.open("r", encoding="utf-8") as handle:
        first_line = handle.readline()
        if not first_line:
            return

        delimiter = "\t" if "\t" in first_line else ","
        headers = [header.strip().lstrip("\ufeff") for header in first_line.split(delimiter)]

        reader = csv.reader(handle, delimiter=delimiter)

        for raw_row in reader:
            # Skip completely empty rows.
            if not raw_row or all(not cell.strip() for cell in raw_row):
                continue

            if len(raw_row) < len(headers):
                raw_row = raw_row + [""] * (len(headers) - len(raw_row))

            row = {headers[idx]: (cell.strip() if isinstance(cell, str) else cell) for idx, cell in enumerate(raw_row)}
            yield row


def aggregate_costs(rows):
    # Roll up spend by service, usage type, and tag coverage.
    total = 0.0
    by_service = defaultdict(float)
    by_usage = defaultdict(float)
    by_service_usage = defaultdict(float)
    tag_missing = defaultdict(lambda: {"rows": 0, "amount": 0.0})

    for row in rows:
        amount = to_float(row.get("amount"))
        total += amount

        service = row.get("service") or "UNKNOWN"
        usage_type = row.get("usage_type") or "UNKNOWN"

        by_service[service] += amount
        by_usage[usage_type] += amount
        by_service_usage[(service, usage_type)] += amount

        # Track rows missing common governance tags.
        for tag in ["App", "Env", "Owner", "CostCenter"]:
            if not row.get(tag):
                tag_missing[tag]["rows"] += 1
                tag_missing[tag]["amount"] += amount

    return total, by_service, by_usage, by_service_usage, tag_missing


def top_items(mapping, limit=5):
    # Sort descending by spend and return the top N.
    return sorted(mapping.items(), key=lambda item: item[1], reverse=True)[:limit]


def write_report(total, by_service, by_usage, by_service_usage, tag_missing):
    # Emit a Markdown summary for quick review.
    lines = []
    lines.append("# FinOps Cost Analysis Summary")
    lines.append("")
    lines.append(f"Total spend (all rows): ${total:,.2f}")
    lines.append("")

    lines.append("## Top services")
    for service, amount in top_items(by_service):
        pct = (amount / total * 100) if total else 0
        lines.append(f"- {service}: ${amount:,.2f} ({pct:.1f}%)")
    lines.append("")

    lines.append("## Top usage types")
    for usage, amount in top_items(by_usage):
        pct = (amount / total * 100) if total else 0
        lines.append(f"- {usage}: ${amount:,.2f} ({pct:.1f}%)")
    lines.append("")

    lines.append("## Top service + usage pairs")
    for (service, usage), amount in top_items(by_service_usage):
        pct = (amount / total * 100) if total else 0
        lines.append(f"- {service} / {usage}: ${amount:,.2f} ({pct:.1f}%)")
    lines.append("")

    lines.append("## Tag coverage (missing)")
    for tag, stats in tag_missing.items():
        pct = (stats["amount"] / total * 100) if total else 0
        lines.append(
            f"- {tag}: {stats['rows']} rows missing, ${stats['amount']:,.2f} ({pct:.1f}% of spend)"
        )
    lines.append("")

    OUTPUT_PATH.write_text("\n".join(lines), encoding="utf-8")


def main():
    rows = list(read_rows(DATA_PATH))
    total, by_service, by_usage, by_service_usage, tag_missing = aggregate_costs(rows)
    write_report(total, by_service, by_usage, by_service_usage, tag_missing)


if __name__ == "__main__":
    main()
    
print("Script finished running")
