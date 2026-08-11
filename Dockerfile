FROM node:22-alpine AS cloner

# Install git
RUN apk add --no-cache git

# Build arguments for GitHub credentials
ARG GITHUB_TOKEN
ARG GITHUB_REPO

# Clone the repository
# We use oauth2 for token-based authentication with GitHub
RUN git clone https://oauth2:${GITHUB_TOKEN}@${GITHUB_REPO} /app

# Final runner stage
FROM node:22-alpine AS runner

WORKDIR /app

# Install build dependencies for better-sqlite3 (node-gyp)
RUN apk add --no-cache python3 make g++ sqlite-dev

# Copy the cloned repository from the cloner stage
# This ensures the GITHUB_TOKEN used in the previous stage isn't included in the final image layers
COPY --from=cloner /app /app

# Install dependencies (including devDependencies for build)
RUN npm ci

# Build the Next.js app
RUN npm run build

# Ensure the data and Next.js cache directories exist with correct permissions
RUN mkdir -p /app/data /app/.next/cache/images /app/.next/cache/fetch-cache \
    && chown -R node:node /app

# Use a non-root user for better security
USER node

# Expose the default port
EXPOSE 3000

# Set environment variables for production
ENV NODE_ENV=production
ENV PORT=3000

# Start the application
CMD ["npm", "start"]
