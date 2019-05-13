FROM skypilot/node10-dev

ARG PACKAGE_NAME
ARG VERSION

RUN npm install -g prisma \
  graphql \
  graphql-cli


# TODO: Replace the existing Bash prompt rather than overriding it
RUN echo "export PS1=\"\u@${PACKAGE_NAME}:${VERSION} [\w] \$ \"" >> /root/.bashrc

CMD 'bash'
