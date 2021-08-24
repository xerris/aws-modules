{
"openapi" = "3.0.1"
"info" = {
  "title"   = "${apiname}"
  "version" = "1.0"
}

"paths" = {
%{ for kl1, vl1 in config ~}
  "${kl1}" = {
%{ for kl2, vl2 in vl1 ~}
    "${kl2}" = {
%{ for kl3, vl3 in vl2 ~}
%{~ if kl3 == "lambda_details" ~}
       "x-amazon-apigateway-integration" = {
          "httpMethod"           = "POST"
          "payloadFormatVersion" = "1.0"
%{ for kl4, vl4 in vl3 ~}
%{ if kl4 != "lambda_name" ~}
          "${kl4}" = "${vl4}"
%{ endif ~}
%{ endfor ~}
       },
%{ else ~}
%{ if length(vl3) > 0 ~}
      "${kl3}": [ 
        {
%{ for kl4, vl4 in vl3 ~}
%{ for kl5, vl5 in vl4 ~}
          "${kl5}" = "${vl5}"
%{ endfor ~}
%{ endfor ~}
          "required": "true",
          "schema": {
            "type": "string"
          }
       }
      ]
%{ else ~}
      "parameters": []
%{ endif ~}      
%{ endif ~}
%{ endfor ~}
    }
%{ endfor ~}
%{ endfor ~}
  }
}
}
}