from faker import Faker
import random
import boto3
import json
import time

def put_record_to_kinesis(stream_name, record_data):
    # Initialize the Kinesis client
    kinesis_client = boto3.client('kinesis', region_name='us-east-1')  # Change the region as needed

    # Convert record_data to JSON format
    record_data_json = json.dumps(record_data)

    try:
        # Put the record into the Kinesis Data Stream
        response = kinesis_client.put_record(
            StreamName=stream_name,
            Data=record_data_json,
            PartitionKey="partition_key"  # Replace "partition_key" with your actual partition key
        )
        print("Record inserted successfully. ShardId:", response['ShardId'])
    except Exception as e:
        print("Error:", e)

# Example usage:

fake = Faker()

def generate_record():
    record = {
        "name": random.choice(["Person1", "Person2", "Person3", "Person4"]),
        "date": fake.date_time_this_year().strftime('%Y-%m-%d'),
        "year": fake.date_time_this_year().strftime('%Y'),
        "month": fake.date_time_this_year().strftime('%m'),
        "day": fake.date_time_this_year().strftime('%d'),
        "column_to_update_integer": random.randint(0, 1000000000),
        "column_to_update_string": random.choice(["White", "Red", "Yellow", "Silver"])
    }
    return record


def main():
    num_records = 100
    stream_name = "hudi-kinesis-stream"

    # Generate 10 records
    for _ in range(num_records):
        record_data = generate_record()
        print(f"generated fake record: {record_data}")
        put_record_to_kinesis(stream_name, record_data)
        time.sleep(1)


if __name__ == "__main__":
    main()