./public/upload.rb \
    --name test \
    --project p60 \
    --design test_design \
    --stage sta \
    --path  /home/jiangxi/rails/bootstrap-table-dev/ \
    --data test_input/test.flat.json

./public/upload.rb \
    --name test \
    --project p20 \
    --design test_core \
    --stage sta \
    --path  /home/jiangxi/axpi_dev/ \
    --data test_input/test.flat2.json

./public/upload.rb \
    --name stest \
    --project p20 \
    --design test_design \
    --stage syn \
    --path  /home/jiangxi/test/ \
    --data test_input/test.flat3.json

./public/upload.rb \
    --name pic \
    --project mp80 \
    --design t_core \
    --stage layout \
    --path  /home/jiangxi/rails/sheet_view/ \
    --data test_input/test.flat4.pic.json \
    --picture "/mnt/c/Users/jiangxi/Pictures/Screenshots/屏幕截图_20221101_153610.png" \
    --picture "/mnt/c/Users/jiangxi/Pictures/屏幕截图 2021-01-20 101622.png"

./public/upload.rb \
    --private \
    --name test \
    --project p60 \
    --design test_design \
    --stage sta \
    --path  /home/jiangxi/circt/ \
    --data test_input/test.flat.json

./public/upload.rb \
    --private \
    --name test \
    --project p20 \
    --design test_core \
    --stage sta \
    --path  /home/jiangxi/work/ \
    --data test_input/test.flat2.json
