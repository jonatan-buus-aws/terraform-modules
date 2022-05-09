#set($allParams = $input.params())
{
    "stateMachineArn": "${authorize_payment_step_function_arn}", 
    "input" : "{   
        \\"body\\": $util.escapeJavaScript($input.json('$') ),
        #foreach($type in $allParams.keySet())
            #set($params = $allParams.get($type))
        \\"$type\\" : {
            #foreach($paramName in $params.keySet())
            \\"$paramName\\" : \\"$util.escapeJavaScript($params.get($paramName))\\"
                #if($foreach.hasNext),#end
            #end
        }
            #if($foreach.hasNext),#end
        #end
    }"
}