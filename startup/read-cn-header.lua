-- This script reads the header that NGINX defined with the CN of the Client Cert
-- and puts it on a new header of the response, showing that all the circuit works OK
local value_with_the_cn = kong.request.get_header('X-test-header-cn')
kong.response.set_header('X-output-response-header', value_with_the_cn)
