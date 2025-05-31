#See https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/docker/building-net-docker-images
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /code

# 设置环境变量
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
ENV DOTNET_NOLOGO=1
ENV NUGET_XMLDOC_MODE=skip

# 复制NuGet配置（如果存在）
COPY [".config/", ".config/"]

# 复制解决方案文件和公共配置
COPY ["*.sln", "./"]
COPY ["common.props", "./"]

# 复制所有项目文件
COPY ["src/Ray.BiliBiliTool.Web/Ray.BiliBiliTool.Web.csproj", "src/Ray.BiliBiliTool.Web/"]
COPY ["src/Ray.BiliBiliTool.Web.Client/Ray.BiliBiliTool.Web.Client.csproj", "src/Ray.BiliBiliTool.Web.Client/"]
COPY ["src/Ray.BiliBiliTool.Application/Ray.BiliBiliTool.Application.csproj", "src/Ray.BiliBiliTool.Application/"]
COPY ["src/Ray.BiliBiliTool.Application.Contracts/Ray.BiliBiliTool.Application.Contracts.csproj", "src/Ray.BiliBiliTool.Application.Contracts/"]
COPY ["src/Ray.BiliBiliTool.Domain/Ray.BiliBiliTool.Domain.csproj", "src/Ray.BiliBiliTool.Domain/"]
COPY ["src/Ray.BiliBiliTool.DomainService/Ray.BiliBiliTool.DomainService.csproj", "src/Ray.BiliBiliTool.DomainService/"]
COPY ["src/Ray.BiliBiliTool.Config/Ray.BiliBiliTool.Config.csproj", "src/Ray.BiliBiliTool.Config/"]
COPY ["src/Ray.BiliBiliTool.Agent/Ray.BiliBiliTool.Agent.csproj", "src/Ray.BiliBiliTool.Agent/"]
COPY ["src/Ray.BiliBiliTool.Infrastructure/Ray.BiliBiliTool.Infrastructure.csproj", "src/Ray.BiliBiliTool.Infrastructure/"]
COPY ["src/Ray.BiliBiliTool.Infrastructure.EF/Ray.BiliBiliTool.Infrastructure.EF.csproj", "src/Ray.BiliBiliTool.Infrastructure.EF/"]
COPY ["src/BlazingQuartz.Core/BlazingQuartz.Core.csproj", "src/BlazingQuartz.Core/"]
COPY ["src/BlazingQuartz.Jobs/BlazingQuartz.Jobs.csproj", "src/BlazingQuartz.Jobs/"]
COPY ["src/BlazingQuartz.Jobs.Abstractions/BlazingQuartz.Jobs.Abstractions.csproj", "src/BlazingQuartz.Jobs.Abstractions/"]

# 清理和配置NuGet
RUN dotnet nuget locals all --clear

# 添加官方NuGet源并进行restore，增加重试和详细日志
RUN dotnet restore "src/Ray.BiliBiliTool.Web/Ray.BiliBiliTool.Web.csproj" \
    --disable-parallel \
    --verbosity detailed \
    --runtime linux-x64 \
    --force \
    --no-cache \
    || (echo "First restore attempt failed, retrying..." && \
        dotnet restore "src/Ray.BiliBiliTool.Web/Ray.BiliBiliTool.Web.csproj" \
        --disable-parallel \
        --verbosity detailed \
        --runtime linux-x64 \
        --force \
        --no-cache)

# 复制所有源代码
COPY . .

# 切换到项目目录并构建
WORKDIR "/code/src/Ray.BiliBiliTool.Web"
RUN dotnet build "Ray.BiliBiliTool.Web.csproj" -c Release -o /app/build --no-restore

FROM build AS publish
RUN dotnet publish "Ray.BiliBiliTool.Web.csproj" -c Release -o /app/publish --no-restore --no-build

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# 更新包管理器并清理
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["dotnet", "Ray.BiliBiliTool.Web.dll"]
