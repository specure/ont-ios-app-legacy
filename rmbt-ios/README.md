# Open Nettest iOS legacy application
The code to versions 2.*.* of Open Nettest iOS application.

## Installation and configuration

1. To install the necessary libraries run:

```bash
$ pod install
```

or, if you are using a non-Intel based Mac:

```bash
$ arch -x86_64 pod install
```

2. Set the API key for Fabric, the access token for Mapbox, the GADApplicationIdentifier and SKAdNetworkItems for Google Analytics in `Configurations/ONT/RMBT-Info.plist`.

3. Set CONFIG_BUNDLE_ID, CONFIG_BUNDLE_NAME, CONFIG_CUSTOMER_NAME in `Configurations/ONT/Shared.xcconfig`.

4. Replace the mock `Resources/ONT/GoogleService-Info.plist` with your own one.

5. Adjust the server URLs in `Sources/RMBTONTConfigurationV2.swift`.

6. Adjust the color scheme and other flavor-specific values in the `Sources/Customers/ONT/*.swift` files, if needed.

7. Replace all `example` values in the `*.strings` files.

8. Launch the project and configure `Signing and Capabilites`, replace `example` values in `Build Settings`.