#!/bin/bash

CLIENT=$1

if [ -z "$CLIENT" ]; then
    echo "Missing CLIENT parameter, i.e.: ./build.sh CLIENTNAME";
    exit 1;
fi

########################################
## SCRIPT CONFIG
########################################
BASEPATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd);
JAVABIN="/usr/bin/java";


echo "##################################";
echo "## 2W BUILD SCRIPT";
echo "##################################";
echo

########################################
## Contents Book
########################################
OUTPUTFOLDER="$BASEPATH/../client/$CLIENT/build/content";
echo "[CONTENT] Cleaning up";
rm -rf $OUTPUTFOLDER;
mkdir -p $OUTPUTFOLDER;
cd $OUTPUTFOLDER;

echo "[CONTENT] Decompressing Book";
unzip -q $BASEPATH/book/Book_Contents.zip;

echo "[CONTENT] Running trafo";
cd $BASEPATH;
$JAVABIN -jar $BASEPATH/lib/saxon/saxon9he.jar \
    $OUTPUTFOLDER/all-language-data.xml \
    $BASEPATH/xsl/renderPages.xsl > $OUTPUTFOLDER/pages.html

########################################
## First Style Object only
########################################
OUTPUTFOLDER="$BASEPATH/../client/$CLIENT/build/styles/style1";
echo "[STYLE 1] Cleaning up";
rm -rf $OUTPUTFOLDER;
mkdir -p $OUTPUTFOLDER;
cd $OUTPUTFOLDER;

echo "[STYLE 1] Decompressing Book";
unzip -q $BASEPATH/book/Book_Style_Service_Manual.zip;

echo "[STYLE 1] Running trafo";
cd $BASEPATH;
$JAVABIN -jar $BASEPATH/lib/saxon/saxon9he.jar \
    $OUTPUTFOLDER/all-language-data.xml \
    $BASEPATH/xsl/renderStyles.xsl > $OUTPUTFOLDER/style.css
