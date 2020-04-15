# EngineMonitor
An iOS app that can graphically show real-time data from a GRT EIS-4000 engine monitor.

This app displays best in Slide Over mode. It will work in full screen mode but the gauges don't look very good.

This was my first attempt at using SwiftUI so I am sure that I didn't use best practices everywhere. Please let me know if you have any suggestions on how I could do it better.

It receives the data in UDP packets over a WiFi network. You can see more about how these packets are generated in the Serial-UDP project here<NEED LINK>.