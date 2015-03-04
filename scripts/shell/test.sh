# test.sh
fpath=$(pwd)

#Upload File 
#name_final="ind063gwa028.caas.local-20141016-1011.xml"
name_final="IND065GWA049.caas.local-20141012-1109.xml"
xml_final=$fpath/$name_final
uri_name=$(echo $name_final | sed 's/\./%2E/g')

echo "xml final: $xml_final"
echo "uri_name: $uri_name"
uri="http://172.31.63.28/babychefAPI/api/serverFileUpload?filename=$uri_name"
curl -F upload=@$xml_final $uri
