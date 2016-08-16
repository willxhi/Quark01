httpurl='http://192.168.51.193:8888/reports/rwservlet/showjobs?server=rptsvr_delta64_fr_inst&queuetype=current'


curl -s $httpurl | awk '/class=OraInstructionText/,/\/SPAN/'
curl -s $httpurl | awk '/OraTableCellTextBand/,/\/td/'

