## Zip the function to be run at function App
data "archive_file" "init" {
    type = "zip"
    source_file = "${path.module}/Projet-nodejs/hello.js"
    output_path = "${path.module}/hello.zip"
}

