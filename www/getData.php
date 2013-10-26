<?php 

$string = file_get_contents("data.json");
echo '{
		"cols":[
			{"type":"string"},
			{"label":"Sentiment", "type":"number"},
			{"label":"Price (GBP)", "type":"number"}
		],
		"rows":[';
echo $string;
echo '] }';

?>
