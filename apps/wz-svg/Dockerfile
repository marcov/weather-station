FROM mcr.microsoft.com/playwright:v1.62.1-noble

WORKDIR /wz-svg

COPY apps/wz-svg/package.json apps/wz-svg/package-lock.json ./
RUN npm ci --omit=dev --no-audit --no-fund

COPY apps/wz-svg/extract.mjs ./

ENTRYPOINT ["node", "/wz-svg/extract.mjs"]
CMD ["/destdir/wz_meteogram.svg"]
