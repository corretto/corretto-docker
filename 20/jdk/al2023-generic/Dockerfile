FROM amazonlinux:2023

ARG version=20.0.2.10-1
# In addition to installing the Amazon corretto, we also install
# libs that are needed for jdk to be functional

# The logic and code related to Fingerprint is contributed by @tianon in a Github PR's Conversation
# Comment = https://github.com/docker-library/official-images/pull/7459#issuecomment-592242757
# PR = https://github.com/docker-library/official-images/pull/7459
RUN set -eux \
    && export GNUPGHOME="$(mktemp -d)" \
    && curl -fL -o corretto.key https://yum.corretto.aws/corretto.key \
    && dnf install gnupg2 -y --allowerasing \
    && dnf install findutils -y \
    && gpg --batch --import corretto.key \
    && gpg --batch --export --armor '6DC3636DAE534049C8B94623A122542AB04F24E3' > corretto.key \
    && rpm --import corretto.key \
    && rm -r "$GNUPGHOME" corretto.key \
    && curl -fL -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo \
    && grep -q '^gpgcheck=1' /etc/yum.repos.d/corretto.repo \
    && echo "priority=9" >> /etc/yum.repos.d/corretto.repo \
    && dnf install -y java-20-amazon-corretto-devel-$version \
    && (find /usr/lib/jvm/java-20-amazon-corretto -name src.zip -delete || true) \
    && dnf remove -y findutils \
    && dnf install -y fontconfig freetype libjpeg dejavu-sans-fonts dejavu-serif-fonts dejavu-sans-mono-fonts libjpeg \
    && dnf clean all

ENV LANG C.UTF-8
# JVM by default only uses 25% of container memory, since we are running only one JVM we can safely boost this with a bit of extra room for agents/sidecars.
ENV JAVA_TOOL_OPTIONS "-XX:InitialRAMPercentage=60.0 -XX:MaxRAMPercentage=80.0"
ENV JAVA_HOME=/usr/lib/jvm/java-20-amazon-corretto

