@ECHO OFF

set SAXON=../../../../build/lib/saxon/saxon9he.jar
set XSL_BASE_PATH=../../../../build/xsl/pdf
set TEMP_FOLDER_PATH=temp
set CONTENT_FOLDER_PATH=../content
set STYLES_FOLDER_PATH=../styles/style1

rem prepare style object content
java -jar %SAXON% %STYLES_FOLDER_PATH%/all-language-data.xml %XSL_BASE_PATH%/style/select-template.xsl > %TEMP_FOLDER_PATH%/style_step1.xml safety-information="2" tables=1 page-width="210" page-height="297" number-of-columns="2" headeroutside="main-title" headermiddle="logo" headerinside="publish-date" footeroutside="product-name" footermiddle="logo" footerinside="page-number" basePath="../../../../.."
java -jar %SAXON% %TEMP_FOLDER_PATH%/style_step1.xml %XSL_BASE_PATH%/style/clean-up.xsl > %TEMP_FOLDER_PATH%/style_step2.xml
java -jar %SAXON% %TEMP_FOLDER_PATH%/style_step2.xml %XSL_BASE_PATH%/style/merge.xsl > %TEMP_FOLDER_PATH%/style_step3.xml
java -jar %SAXON% %TEMP_FOLDER_PATH%/style_step3.xml %XSL_BASE_PATH%/style/resolve-element-inheritance.xsl > %TEMP_FOLDER_PATH%/style_step4.xml

rem combine style and content
java -jar %SAXON% %CONTENT_FOLDER_PATH%/all-language-data.xml xsl/combine.xsl > %TEMP_FOLDER_PATH%/step1.xml

rem prepare content
java -jar %SAXON% %TEMP_FOLDER_PATH%/step1.xml %XSL_BASE_PATH%/book-preprocess/production-preprocess.xsl > %TEMP_FOLDER_PATH%/step2.xml image-type="stroke-color" marginalia="marginalia-yes" basePath="../../../../.."
java -jar %SAXON% %TEMP_FOLDER_PATH%/step2.xml %XSL_BASE_PATH%/preprocess/smc.preprocess.xsl > %TEMP_FOLDER_PATH%/step3.xml
java -jar %SAXON% %TEMP_FOLDER_PATH%/step3.xml %XSL_BASE_PATH%/fo/caller.xsl > %TEMP_FOLDER_PATH%/step4.xml
java -jar %SAXON% %TEMP_FOLDER_PATH%/step4.xml %XSL_BASE_PATH%/fo/psmi.xsl > %TEMP_FOLDER_PATH%/step5.xml
java -jar %SAXON% %TEMP_FOLDER_PATH%/step5.xml %XSL_BASE_PATH%/fo/fo-cleanup.xsl > %TEMP_FOLDER_PATH%/step6.xml

rem generate pdf
build-pdf-only.bat