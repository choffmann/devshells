{
  description = "Development enviroment for Android";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs = inputs: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      inputs.nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [inputs.self.overlays.default];
          };
        });
  in {
    devShells = forEachSupportedSystem ({pkgs}: {
      default = let
        android = pkgs.androidenv.composeAndroidPackages {
          platformVersions = ["34"];
          buildToolsVersions = ["35.0.0"];
          abiVersions = ["x86_64"];
          includeEmulator = true;
          includeSystemImages = true;
          systemImageTypes = ["google_apis"];
          cmakeVersions = ["3.22.1"];
          ndkVersion = "26.3.11579264";
        };
      in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            android.androidsdk
            openjdk17
            gradle
            android-tools
            kotlin-language-server
            ktlint
            jdt-language-server
            nodejs_24
            yarn
            libGL
            libxkbcommon
            alsa-lib
            zlib
            ncurses5
            udev
          ];

          shellHook = ''
            export ANDROID_SDK_ROOT="${android.androidsdk}"
            export ANDROID_HOME="${android.androidsdk}"
            export JAVA_HOME="${pkgs.openjdk17}"
            export PATH="$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/tools/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"

            echo
            echo "Android dev shell aktiv"
            echo "SDK: $ANDROID_SDK_ROOT"
            echo "Java: $JAVA_HOME"
            echo
            echo "First use? crate AVD:"
            echo "  avdmanager create avd -n pixel_xl_api34 -k 'system-images;android-34;google_apis;x86_64' --device 'pixel_xl'"
            echo "Start emulator:"
            echo "  emulator -avd pixel_xl_api34 -netdelay none -netspeed full"
            echo
          '';
        };
    });
  };
}
