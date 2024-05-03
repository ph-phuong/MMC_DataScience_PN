# Task 1
import pandas as pd
def access_pd():
    while True:
        try:
            file_name = input("Enter a filename: ")
            df = pd.read_csv(file_name, sep='\t')
        except FileNotFoundError:
            print("Sorry, I can't find this filename")
            return None
        else:
            print(f'Successfully opened {file_name}')
            return df


def analyzing_pd():
    df = access_pd()

    valid_rows = 0
    invalid_rows = 0

    for index, row in df.iterrows():
        # Kiểm tra xem hàng có chứa đúng 26 giá trị và bắt đầu bằng "N#" theo sau là 8 ký tự số không
        if (len(row) == 26) and (re.match(r'^N\d{8}$', row[0]) is not None):
            valid_rows += 1
        else:
            invalid_rows += 1
            print("Invalid line of df: does not contain exactly 26 values:")
            print(row)

    print('**** ANALYZING ****')

    print('**** REPORT ****')
    print('Total valid lines of df: ', valid_rows)
    print('Total invalid lines of df: ', invalid_rows)


analyzing_pd()