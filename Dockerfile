# net 6
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS builder

WORKDIR /app

# Copy everything
COPY . ./ 

# Restore as distinct layers
RUN dotnet restore

# Build and publish a release
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=builder /app/out .
ENTRYPOINT ["dotnet", "AspNetCoreApp.dll"]