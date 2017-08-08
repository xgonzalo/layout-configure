<?php

function generatePDF() {
    $params = $_GET;
    $client = $params['client'];
    $basePath = sprintf("%s/..", getcwd());
    $configFile = $basePath . "/client/".$_GET['client']."/build/pdf/fopconfig/config.php";
    
    if(file_exists($configFile))
        include($configFile);
    
    $saxon = sprintf("%s/build/lib/saxon/saxon9he.jar", $basePath);
    $fop = sprintf("%s/build/bin/fop-2.0/fop", $basePath);
    $xslBasePath = sprintf("%s/build/xsl/pdf", $basePath);

    $clientPath = sprintf("%s/client/%s/build", $basePath, $client);
    $tempPath = sprintf("%s/pdf/temp", $clientPath);
    $tempPrefix = "pdf_" . uniqid();
    
    if(getenv("JAVA_HOME"))
        $cmd = getenv("JAVA_HOME") . "/bin/java " . getenv("FOP_OPTS") . " -jar $saxon";
    else
        $cmd = "java -jar $saxon";
		
    $contentPath = sprintf("%s/content", $clientPath);
    $stylePath = sprintf("%s/styles/style1", $clientPath);
    //$pdfFile = tempnam(sys_get_temp_dir(), 'PDF');
    $pdfFile = sprintf("%s/%s_final.pdf", $tempPath, $tempPrefix);
    // prepare style object content
    
    $safetyInformation = substr($_GET['safety-information'], -1);
    $tables = substr($_GET['tables'], -1);
    
    $pageWidth = $_GET['page-width'];
    $pageHeight = $_GET['page-height'];
    
    $cols = $_GET['number-of-columns'];
    
    $headerOutside = $_GET['headeroutside'];
    $headerInside = $_GET['headerinside'];
    $headerMiddle = $_GET['headermiddle'];
    $footerInside = $_GET['footerinside'];
    $footerMiddle = $_GET['footermiddle'];
    $footerOutside = $_GET['footeroutside'];
    
    $imageType = $_GET['image-type'];
    if(empty($imageType))
    {
        $imageType = 'halftone-with-highlighting'; 
    }
    $marginalia = $_GET['marginalia'];
    
    $smcImgWidth = 591;
    $smcImgHeight = 473;
    
    $personalizationImage = $_GET['personalizationimage'];
    if(!empty($personalizationImage))
    {
        list($smcImgWidth, $smcImgHeight) = getimagesize(sprintf("%s/uploads/%s", $basePath, $personalizationImage));
    }
    
    $personalizationLogo = $_GET['personalizationlogo'];
    
    $logoHeight = 0;
    $logoWidth = 0;
    
    if(!empty($personalizationLogo))
    {
        list($logoWidth, $logoHeight) = getimagesize(sprintf("%s/uploads/%s", $basePath, $personalizationLogo));
    }
    
    $basePathParam = $basePath;
    
    exec(sprintf('%s %s/all-language-data.xml %s/style/select-template.xsl > %s/%s_style_step1.xml  safety-information="%s" tables=%s page-width="%s" page-height="%s" number-of-columns="%s" headeroutside="%s" headermiddle="%s" headerinside="%s" footeroutside="%s" footermiddle="%s" footerinside="%s" personalizationimage="%s" personalizationlogo="%s" basePath="%s" img-width="%s" img-height="%s" logo-width="%s" logo-height="%s"', $cmd, $stylePath, $xslBasePath, $tempPath, $tempPrefix, $safetyInformation, $tables, $pageWidth, $pageHeight, $cols, $headerOutside, $headerMiddle, $headerInside, $footerOutside, $footerMiddle, $footerInside, $personalizationImage, $personalizationLogo, $basePathParam, $smcImgWidth, $smcImgHeight, $logoWidth, $logoHeight));
    
    exec(sprintf('%s %s/%s_style_step1.xml %s/style/clean-up.xsl > %s/%s_style_step2.xml', $cmd, $tempPath, $tempPrefix, $xslBasePath, $tempPath, $tempPrefix)); 
    exec(sprintf('%s %s/%s_style_step2.xml %s/style/merge.xsl > %s/%s_style_step3.xml', $cmd, $tempPath, $tempPrefix, $xslBasePath, $tempPath, $tempPrefix));
    exec(sprintf('%s %s/%s_style_step3.xml %s/style/resolve-element-inheritance.xsl > %s/%s_style_step4.xml page-width="%s" page-height="%s"', $cmd, $tempPath, $tempPrefix, $xslBasePath, $tempPath, $tempPrefix, $pageWidth, $pageHeight));
    
    // combine style and content
    exec(sprintf('%s %s/all-language-data.xml %s/pdf/xsl/combine.xsl > %s/%s_step1.xml styles="%s/%s_style_step4.xml"', $cmd, $contentPath, $clientPath, $tempPath, $tempPrefix, $tempPath, $tempPrefix));
     
    //prepare content
    exec(sprintf('%s %s/%s_step1.xml %s/book-preprocess/production-preprocess.xsl > %s/%s_step2.xml  image-type="%s" marginalia="%s" basePath="%s"', $cmd, $tempPath, $tempPrefix, $xslBasePath, $tempPath, $tempPrefix, $imageType, $marginalia, $basePathParam));
    exec(sprintf('%s %s/%s_step2.xml %s/preprocess/smc.preprocess.xsl > %s/%s_step3.xml', $cmd, $tempPath, $tempPrefix, $xslBasePath, $tempPath, $tempPrefix));
    exec(sprintf('%s %s/%s_step3.xml %s/fo/caller.xsl > %s/%s_step4.xml', $cmd, $tempPath, $tempPrefix, $xslBasePath, $tempPath, $tempPrefix));
    exec(sprintf('%s %s/%s_step4.xml %s/fo/psmi.xsl > %s/%s_step5.xml', $cmd, $tempPath, $tempPrefix, $xslBasePath, $tempPath, $tempPrefix));
    exec(sprintf('%s %s/%s_step5.xml %s/fo/fo-cleanup.xsl > %s/%s_step6.xml', $cmd, $tempPath, $tempPrefix, $xslBasePath, $tempPath, $tempPrefix));
    
    // generate PDF
    exec(sprintf("%s -r -c %s/pdf/fopconfig/fopconfig.xml -fo %s/%s_step6.xml -pdf %s", $fop, $clientPath, $tempPath, $tempPrefix, $pdfFile));
    
    header("Content-type:application/pdf");
    readfile($pdfFile);
    
    unlink($pdfFile);
    unlink(sprintf('%s/%s_style_step1.xml', $tempPath, $tempPrefix));
    unlink(sprintf('%s/%s_style_step2.xml', $tempPath, $tempPrefix));
    unlink(sprintf('%s/%s_style_step3.xml', $tempPath, $tempPrefix));
    unlink(sprintf('%s/%s_style_step4.xml', $tempPath, $tempPrefix));
    unlink(sprintf('%s/%s_step1.xml', $tempPath, $tempPrefix));
    unlink(sprintf('%s/%s_step2.xml', $tempPath, $tempPrefix));
    unlink(sprintf('%s/%s_step3.xml', $tempPath, $tempPrefix));
    unlink(sprintf('%s/%s_step4.xml', $tempPath, $tempPrefix));
    unlink(sprintf('%s/%s_step5.xml', $tempPath, $tempPrefix));
    unlink(sprintf('%s/%s_step6.xml', $tempPath, $tempPrefix));
}

generatePDF();