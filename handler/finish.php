<?php

function send_mail(){
    $to = $_POST["values"]["email"];
    $from = "dokfitter@2wgmbh.de";
    $subject = '2Wdokfitter';

    $headers = "From: $from \r\n";
    $headers .= "Reply-To: $from  \r\n";
    $headers .= "MIME-Version: 1.0\r\n";
    $headers .= "Content-Type: text/html; charset=UTF-8\r\n";
    
    $message = '<html><body><font face="Arial">';
    
    if($_POST["values"]["contact"] == "yes")
    {
        $message .= '<p>Liebe Interessentin, lieber Interessent,</p>';
        $message .= '<p>schön, dass Sie unseren 2Wdokfitter ausprobiert haben! Wir hoffen, es hat Ihnen Spaß gemacht. Wenn Sie Wünsche oder Anregungen zu unserem Tool haben, dann freuen wir uns über Ihre Rückmeldung: </p>';
        $message .= '<p><a href="mailto:dokfitter@2wgmbh.de">dokfitter@2wgmbh.de</a></p>';
        $message .= '<p>Hier finden Sie Ihre gespeicherte Konfiguration, die Sie jederzeit wieder aufrufen und bei Bedarf ausdrucken können:</p>';
        $message .= '<p></p>';
        $message .= '<p><a href="'.$_POST["url"].'">'.$_POST["url"].'</a></p>';
        $message .= '<p>Ihre Auswal als PDF Datei herunterladen: <a href="'.$_POST["pdfUrl"].'">PDF</a></p>';
        $message .= '<p>In unserem unverbindlichen Beratungsgespräch können Sie uns gerne Fragen dazu stellen. Einer unserer Mitarbeiter wird sich in Kürze mit Ihnen in Verbindung setzen.</p>';
        $message .= '<p>Mit freundlichen Grüßen aus München</p>';
        $message .= '<p>Ihr 2Wdokfitter-Team</p>';
    }
    else
    {
        $message .= '<p>Liebe Interessentin, lieber Interessent,</p>';
        $message .= '<p>schön, dass Sie unseren 2Wdokfitter ausprobiert haben! Wir hoffen, es hat Ihnen Spaß gemacht. Wenn Sie Wünsche oder Anregungen zu unserem Tool haben, dann freuen wir uns über Ihre Rückmeldung: </p>';
        $message .= '<p><a href="mailto:dokfitter@2wgmbh.de">dokfitter@2wgmbh.de</a></p>';
        $message .= '<p>Hier finden Sie Ihre gespeicherte Konfiguration, die Sie jederzeit wieder aufrufen und bei Bedarf ausdrucken können:</p>';
        $message .= '<p></p>';
        $message .= '<p><a href="'.$_POST["url"].'">'.$_POST["url"].'</a></p>';
        $message .= '<p>Ihre Auswal als PDF Datei herunterladen: <a href="'.$_POST["pdfUrl"].'">PDF</a></p>';
        $message .= '<p>Sie haben noch Fragen zu Ihrer Konfiguration oder wünschen ein unverbindliches Beratungsgespräch? Dann setzen Sie sich einfach mit uns in Verbindung. Wir sind gerne für Sie da!</p>';
        $message .= '<p>Mit freundlichen Grüßen aus München</p>';
        $message .= '<p>Ihr 2Wdokfitter-Team</p>';
    }
    
    $message .= '</font></body></html>';
    
    return mail($to, $subject, $message, $headers);
}

function send_mail_2w(){
    $to = $_POST["values"]["email"];
    $from = "dokfitter@2wgmbh.de";
    $subject = '2Wdokfitter';

    if($_SERVER['SERVER_NAME'] == "www.2wgmbh.de")
        $headers = "From: dokfitter@2wgmbh.de \r\n";
    else
        $headers = "From: $from \r\n";
    
    $headers .= "Reply-To: $from  \r\n";
    $headers .= "MIME-Version: 1.0\r\n";
    $headers .= "Content-Type: text/html; charset=UTF-8\r\n";
    
    $message = '<html><body><font face="Arial">';
    
    if($_POST["values"]["contact"] == "yes")
    {
        $message .= '<p>Liebes 2Wdokfitter-Team,</p>';
        $message .= '<p>ein Interessent hat eine neue Konfiguration gespeichert: <a href="'.$_POST["url"].'">'.$_POST["url"].'</a></p>';
        $message .= '<p>Es wurden folgende Kontaktdaten hinterlegt:</p>';
        $message .= '<p>'.$_POST["values"]["salutation"].'</p>';
        $message .= '<p>'.$_POST["values"]["firstname"].'</p>';
        $message .= '<p>'.$_POST["values"]["lastname"].'</p>';
        $message .= '<p>'.$_POST["values"]["company"].'</p>';
        $message .= '<p>'.$_POST["values"]["email"].'</p>';
        $message .= '<p>Ihre Auswal als PDF Datei herunterladen: <a href="'.$_POST["pdfUrl"].'">PDF</a></p>';
        $message .= '<p>Bitte kontaktiert den Interessenten für ein unverbindliches Beratungsgespräch.</p>';
    }
    else
    {
        $message .= '<p>Liebes 2Wdokfitter-Team,</p>';
        $message .= '<p>ein Interessent hat eine neue Konfiguration gespeichert: <a href="'.$_POST["url"].'">'.$_POST["url"].'</a></p>';
        $message .= '<p>Es wurden folgende Kontaktdaten hinterlegt:</p>';
        $message .= '<p>'.$_POST["values"]["salutation"].'</p>';
        $message .= '<p>'.$_POST["values"]["firstname"].'</p>';
        $message .= '<p>'.$_POST["values"]["lastname"].'</p>';
        $message .= '<p>'.$_POST["values"]["company"].'</p>';
        $message .= '<p>'.$_POST["values"]["email"].'</p>';
        $message .= '<p>Ihre Auswal als PDF Datei herunterladen: <a href="'.$_POST["pdfUrl"].'">PDF</a></p>';
        $message .= '<p>Der Interessent meldet sich bei Bedarf.</p>';
    }
    
    $message .= '</font></body></html>';
    
    return mail($to, $subject, $message, $headers);
}

$response = array();
$response["result"] = send_mail() && send_mail_2w();

header('Content-Type: application/json');
print json_encode($response);