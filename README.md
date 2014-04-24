ec2-auditor
===========

Tool used at Crittercism to audit our EC2 instance use

setup
=====

Edit main.rb and change the chef_nodes line to:
  a) use the proper chef server url
  b) refer to your username
  c) refer to the location of our chef certificate that corresponds to the server in step a)
  
  
run
===

To run, first choose which reports you want; each one corresponds to two lines in main.rb
(a line instantiating the report, then one writing it).  You can comment/uncomment any of these reports that you want.

Then do something like so:

ruby main.rb -a \`cat ~/.aws/accesskey\` -s \`cat ~/.aws/secretaccesskeyid\`
