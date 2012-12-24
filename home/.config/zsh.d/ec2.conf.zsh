# Setup Amazon EC2 Commandline tools
export EC2_HOME=~/.ec2
export PATH=$PATH:$EC2_HOME/bin
export EC2_PRIVATE_KEY=`ls $EC2_HOME/pk-*.pem`
export EC2_CERT=`ls $EC2_HOME/cert-*.pem`
export JAVA_HOME="/Library/Java/JavaVirtualMachines/1.6.0_31-b04-415.jdk/Contents/Home"

