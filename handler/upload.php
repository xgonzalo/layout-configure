<?php

function processFile() {
    $uploaddir = dirname(__FILE__) . '/../uploads/';
    $fileNameParts = pathinfo($_FILES['uploadFile']['name']);
    $filename = sha1_file($_FILES['uploadFile']['tmp_name']) . "." . $fileNameParts['extension'];
    $uploadfile = $uploaddir . $filename;

    if (move_uploaded_file($_FILES['uploadFile']['tmp_name'], $uploadfile))
    {
        return $filename;
    } 

}

$filename = processFile();
$response = array();

if($filename)
{
    $response = array();
    $response["filename"] = $filename;
}
else
{
    $response["error"] = 1;
}

header('Content-Type: application/json');
print json_encode($response);