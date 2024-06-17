#!/bin/bash


# Function to copy CSV file based on property
copy_csv() {
  local source_csv="$1"
  local target_csv="$2"

  # Check if the source CSV file exists
  if [ ! -f "$source_csv" ]; then
    echo "Source CSV file $source_csv does not exist."
    return 1
  fi

  # Copy the CSV file
  cp "$source_csv" "$target_csv"

  echo "Copied $source_csv to $target_csv successfully."
}

# Find all CSV files and process them
find . -name "*.csv" | while read -r source_csv; do
  filename=$(basename "$source_csv" .csv)
  echo "source_csv = $source_csv"
  echo "filename = $filename"

  while IFS='=' read -r key value; do
    if [ "$filename" == "$key" ]; then
      target_csv="$(dirname "$source_csv")/${value}.csv"
      copy_csv "$source_csv" "$target_csv"
    fi
  done < "$TRANSFORM_DIR/csv_locale_map.properties"
done

