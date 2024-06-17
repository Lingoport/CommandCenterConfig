#!/bin/bash


# Function to copy CSV file based on property
move_csv() {
  local source_csv="$1"
  local target_csv="$2"

  # Check if the source CSV file exists
  if [ ! -f "$source_csv" ]; then
    echo "Source CSV file $source_csv does not exist."
    return 1
  fi

  # Copy the CSV file
  mv "$source_csv" "$target_csv"

  echo "Moved  $source_csv to $target_csv successfully."
}

# Find all CSV files and process them
find . -name "*.csv" | while read -r target_csv; do
  filename=$(basename "$target_csv" .csv)

  while IFS='=' read -r key value; do
    if [ "$filename" == "$value" ]; then
      source_csv="$(dirname "$target_csv")/${key}.csv"
      move_csv "$target_csv" "$source_csv"
    fi
  done < "$TRANSFORM_DIR/csv_locale_map.properties"
done

