<?php
$cmd = sprintf("%s/../../build/bin/fop-2.0/fop", getcwd());
$xmlFile = sprintf("%s/pdf.xml", getcwd());
$tempFile = tempnam(sys_get_temp_dir(), 'PDF');

exec("$cmd -fo $xmlFile -pdf $tempFile"); 

header("Content-type:application/pdf");
//header("Content-Disposition:attachment;filename='2w_pdf_test.pdf'");
readfile($tempFile);

