FROM public.ecr.aws/codebuild/amazonlinux2-x86_64-standard:4.0
ENV TERRAFORM_VERSION=1.4.2
ENV GO_VERSION=1.20.2
RUN cd /tmp && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && chmod 755 /usr/local/bin/terraform

RUN curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

# RUN cd /tmp && \
#     wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
#     tar -C /usr/local/bin -xzf go${GO_VERSION}.linux-amd64.tar.gz && chmod 755 /usr/local/bin/go && \
#     export PATH=$PATH:/usr/local/bin/go

RUN goenv install 1.20.3 && goenv global 1.20.3