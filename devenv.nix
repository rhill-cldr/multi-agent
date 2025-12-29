{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.PATH_CONFIG = "config";

  # https://devenv.sh/packages/
  packages = with pkgs; [
    awscli2
    cmake
    conftest
    d2
    dbmate
    git
    gh
    graphviz
    grpcurl
    imagemagick
    jq
    mdbook
    mdbook-d2
    mdbook-katex
    mdbook-mermaid
    opentofu
    protobuf
    presenterm
    tilt
    zlib
    flatbuffers
  ];

  # https://devenv.sh/languages/
  # languages.rust.enable = true;

  languages.python = {
    enable = true;
    package = pkgs.python312;
    uv.enable = true;
    uv.sync.enable = true;
    venv.enable = true;
  };

  # Java for building Cloudera parcel validator (thirdparty/cm_ext)
  languages.java = {
    enable = true;
    jdk.package = pkgs.jdk11;  # Java 11 for cm_ext compatibility
    maven.enable = true;
  };

  # JavaScript/Node.js for claude-code-acp adapter
  # Required for ACP integration with Claude Code
  languages.javascript = {
    enable = true;
    npm = {
      enable = true;
      install.enable = true;  # Enable declarative npm package installation
    };
  };

  languages.typescript = {
    enable=true;
  };


  # https://devenv.sh/processes/
  # processes.dev.exec = "${lib.getExe pkgs.watchexec} -n -- ls -la";

  # https://devenv.sh/services/

  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
    extensions = ext: [
      ext.pg_cron  # Scheduled tasks
      ext.age      # Apache AGE - Graph database extension for lineage
    ];
    initialDatabases = [
      { name = "agents"; }
      { name = "metaflow"; }
    ];
    port = 5439;
    listen_addresses = "*";  # Enable TCP from K8s pods and local clients
    settings = {
      shared_preload_libraries = "pg_cron,age";
      "cron.database_name" = "agents";
    };
    initialScript = ''
      CREATE EXTENSION IF NOT EXISTS pg_cron;
      -- AGE extension is created per-database in migrations
    '';
  };

  # https://devenv.sh/basics/
  enterShell = ''
    git --version # Use packages
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/git-hooks/
  # git-hooks.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
