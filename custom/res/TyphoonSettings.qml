/*!
 * @file
 * @brief ST16 Settings Panel
 * @author Gus Grubba <mavlink@grubba.com>
 */

import QtQuick                  2.5
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.2
import QtQuick.Dialogs          1.2
import QtQuick.Layouts          1.2
import QtGraphicalEffects       1.0

import QGroundControl                       1.0
import QGroundControl.Controllers           1.0
import QGroundControl.Controls              1.0
import QGroundControl.FactControls          1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Palette               1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Vehicle               1.0

import TyphoonHQuickInterface               1.0
import TyphoonHQuickInterface.Widgets       1.0

QGCView {
    id:                 qgcView
    viewPanel:          panel
    color:              qgcPal.window
    anchors.fill:       parent
    anchors.margins:    ScreenTools.defaultFontPixelWidth

    property var    _activeVehicle:   QGroundControl.multiVehicleManager.activeVehicle
    property var    _dynamicCameras:  _activeVehicle ? _activeVehicle.dynamicCameras : null
    property bool   _isCamera:        _dynamicCameras ? _dynamicCameras.cameras.count > 0 : false
    property var    _camera:          _isCamera ? _dynamicCameras.cameras.get(0) : null // Single camera support for the time being

    property real   _buttonWidth:     ScreenTools.defaultFontPixelWidth * 16
    property real   _textWidth:       ScreenTools.defaultFontPixelWidth * 40
    property bool   _importAction:    false

    QGCPalette      { id: qgcPal }

    function firmwareVersion() {
        if(_activeVehicle) {
            return _activeVehicle.firmwareCustomMajorVersion + "." + _activeVehicle.firmwareCustomMinorVersion + "." + _activeVehicle.firmwareCustomPatchVersion
        } else {
            return ""
        }
    }

    QGCViewPanel {
        id:             panel
        anchors.fill:   parent
        Column {
            id:                 settingsColumn
            width:              qgcView.width
            spacing:            ScreenTools.defaultFontPixelHeight * 0.5
            anchors.margins:    ScreenTools.defaultFontPixelWidth
            anchors.centerIn:   parent
            //-----------------------------------------------------------------
            Rectangle {
                height:         importRow.height * 2
                width:          ScreenTools.defaultFontPixelWidth * 80
                color:          qgcPal.windowShade
                anchors.horizontalCenter: parent.horizontalCenter
                Row {
                    id:         importRow
                    spacing:    ScreenTools.defaultFontPixelWidth * 4
                    anchors.centerIn: parent
                    QGCButton {
                        text:   qsTr("Import Mission")
                        width:   _buttonWidth
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            _importAction = true
                            rootLoader.sourceComponent = fileCopyDialog
                            mainWindow.disableToolbar()
                        }
                    }
                    QGCLabel {
                        text:   qsTr("Import missions from microSD Card")
                        width:   _textWidth
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
            //-----------------------------------------------------------------
            Rectangle {
                height:         exportRow.height * 2
                width:          ScreenTools.defaultFontPixelWidth * 80
                color:          qgcPal.windowShade
                anchors.horizontalCenter: parent.horizontalCenter
                Row {
                    id:         exportRow
                    spacing:    ScreenTools.defaultFontPixelWidth * 4
                    anchors.centerIn: parent
                    QGCButton {
                        text:   qsTr("Export Data")
                        width:   _buttonWidth
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            _importAction = false
                            rootLoader.sourceComponent = fileCopyDialog
                            mainWindow.disableToolbar()
                        }
                    }
                    QGCLabel {
                        text:   qsTr("Export missions and logs to microSD Card")
                        width:   _textWidth
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
            //-----------------------------------------------------------------
            Rectangle {
                height:         bindRow.height * 2
                width:          ScreenTools.defaultFontPixelWidth * 80
                color:          qgcPal.windowShade
                visible:        !_activeVehicle || (_activeVehicle.rcRSSI === 0 || _activeVehicle.rcRSSI === 255)
                anchors.horizontalCenter: parent.horizontalCenter
                Row {
                    id:         bindRow
                    spacing:    ScreenTools.defaultFontPixelWidth * 4
                    anchors.centerIn: parent
                    QGCButton {
                        text:   qsTr("Manual Bind")
                        width:   _buttonWidth
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            rootLoader.sourceComponent = bindDialog
                            mainWindow.disableToolbar()
                        }
                    }
                    QGCLabel {
                        text:   qsTr("Manually bind RC to vehicle (fly without camera)")
                        width:   _textWidth
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
            //-----------------------------------------------------------------
            Rectangle {
                height:         passwordRow.height * 2
                width:          ScreenTools.defaultFontPixelWidth * 80
                color:          qgcPal.windowShade
                visible:        _activeVehicle && (_camera && !_camera.isCGOET)
                anchors.horizontalCenter: parent.horizontalCenter
                Row {
                    id:         passwordRow
                    spacing:    ScreenTools.defaultFontPixelWidth * 4
                    anchors.centerIn: parent
                    QGCButton {
                        text:   qsTr("Set Password")
                        width:   _buttonWidth
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            passwordDialog.visible = true
                        }
                    }
                    QGCLabel {
                        text:   qsTr("Set connection password")
                        width:   _textWidth
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
            //-----------------------------------------------------------------
            Rectangle {
                height:         updateRow.height * 2
                width:          ScreenTools.defaultFontPixelWidth * 80
                color:          qgcPal.windowShade
                visible:        ScreenTools.isMobile
                anchors.horizontalCenter: parent.horizontalCenter
                Row {
                    id:         updateRow
                    spacing:    ScreenTools.defaultFontPixelWidth * 4
                    anchors.centerIn: parent
                    QGCButton {
                        text:       qsTr("Update Firmware")
                        width:      _buttonWidth
                        enabled:    !TyphoonHQuickInterface.updating
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            if(TyphoonHQuickInterface.checkForUpdate()) {
                                updateDialog.open()
                            } else {
                                noUpdateDialog.open()
                            }
                        }
                        MessageDialog {
                            id:                 noUpdateDialog
                            title:              qsTr("Update Firmware")
                            text:               qsTr("Update file not found.")
                            standardButtons:    StandardButton.Ok
                            onAccepted:         noUpdateDialog.close()
                        }
                        MessageDialog {
                            id:                 updateDialog
                            title:              qsTr("Update Firmware")
                            text:               qsTr("Confirm updating firmware?")
                            standardButtons:    StandardButton.Ok | StandardButton.Cancel
                            onAccepted: {
                                rootLoader.sourceComponent = firmwareUpdate
                                mainWindow.disableToolbar()
                                TyphoonHQuickInterface.updateSystemImage()
                            }
                        }
                    }
                    QGCLabel {
                        text:   qsTr("Update ST16 Firmware (from microSD card)")
                        width:  _textWidth
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
            //-----------------------------------------------------------------
            Rectangle {
                height:         factoryRow.height * 2
                width:          ScreenTools.defaultFontPixelWidth * 80
                color:          qgcPal.windowShade
                visible:        QGroundControl.corePlugin.showAdvancedUI && TyphoonHQuickInterface.isFactoryApp
                anchors.horizontalCenter: parent.horizontalCenter
                Row {
                    id:         factoryRow
                    spacing:    ScreenTools.defaultFontPixelWidth * 4
                    anchors.centerIn: parent
                    QGCButton {
                        text:   qsTr("Factory Test")
                        width:   _buttonWidth
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            TyphoonHQuickInterface.factoryTest()
                        }
                    }
                    QGCLabel {
                        text:   qsTr("Enter Factory Test")
                        width:   _textWidth
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
            Item {
                width:  1
                height: ScreenTools.defaultFontPixelHeight * 0.5
            }
            GridLayout {
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                columnSpacing:      ScreenTools.defaultFontPixelWidth
                columns:            2
                visible:            _activeVehicle
                anchors.horizontalCenter: parent.horizontalCenter
                QGCLabel { text: qsTr("%1 Version:").arg(QGroundControl.appName) }
                QGCLabel { text: QGroundControl.qgcVersion }
                QGCLabel { text: qsTr("Camera Version:") }
                QGCLabel { text: _camera ? _camera.firmwareVersion : "" }
                QGCLabel { text: qsTr("Gimbal Version:") }
                QGCLabel { text: _camera ? _camera.gimbalVersion : "" }
                QGCLabel { text: qsTr("Flight Controller Version:") }
                QGCLabel { text: firmwareVersion() }
                QGCLabel { text: qsTr("Vehicle ID:") }
                QGCLabel { text: _activeVehicle ? _activeVehicle.vehicleUIDStr : "" }
            }
        }
    }
    //-- Import Files
    Component {
        id:             fileCopyDialog
        Item {
            id:         fileCopyDialogItem
            width:      mainWindow.width
            height:     mainWindow.height
            z:          1000000
            MouseArea {
                anchors.fill:   parent
                onWheel:        { wheel.accepted = true; }
                onPressed:      { mouse.accepted = true; }
                onReleased:     { mouse.accepted = true; }
            }
            Rectangle {
                id:             fileCopyDialogShadow
                anchors.fill:   fileCopyDialogRect
                radius:         fileCopyDialogRect.radius
                color:          qgcPal.window
                visible:        false
            }
            DropShadow {
                anchors.fill:       fileCopyDialogShadow
                visible:            fileCopyDialogRect.visible
                horizontalOffset:   4
                verticalOffset:     4
                radius:             32.0
                samples:            65
                color:              Qt.rgba(0,0,0,0.75)
                source:             fileCopyDialogShadow
            }
            Rectangle {
                id:     fileCopyDialogRect
                width:  mainWindow.width   * 0.65
                height: copyCol.height * 1.25
                radius: ScreenTools.defaultFontPixelWidth
                color:  qgcPal.alertBackground
                border.color: qgcPal.alertBorder
                border.width: 2
                anchors.centerIn: parent
                Column {
                    id:                 copyCol
                    width:              fileCopyDialogRect.width
                    spacing:            ScreenTools.defaultFontPixelHeight * 2
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    anchors.centerIn:   parent
                    QGCLabel {
                        text:           _importAction ? qsTr("Import Mission Files") : qsTr("Export Data Files")
                        font.family:    ScreenTools.demiboldFontFamily
                        font.pointSize: ScreenTools.largeFontPointSize
                        color:          qgcPal.alertText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Rectangle {
                        color:          qgcPal.window
                        width:          exportUTMCheck.width  + (ScreenTools.defaultFontPixelWidth * 4)
                        height:         exportUTMCheck.height + ScreenTools.defaultFontPixelHeight
                        radius:         4
                        visible:        !_importAction
                        anchors.horizontalCenter: parent.horizontalCenter
                        QGCCheckBox {
                            id:                 exportUTMCheck
                            text:               qsTr("Export UTM Telemetry")
                            checked:            false
                            enabled:            !TyphoonHQuickInterface.copyingFiles
                            anchors.centerIn:   parent
                        }
                    }
                    ProgressBar {
                        width:          parent.width * 0.75
                        orientation:    Qt.Horizontal
                        minimumValue:   0
                        maximumValue:   100
                        value:          TyphoonHQuickInterface.updateProgress
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    QGCLabel {
                        text:           TyphoonHQuickInterface.copyMessage
                        color:          qgcPal.alertText
                        font.family:    ScreenTools.demiboldFontFamily
                        font.pointSize: ScreenTools.mediumFontPointSize
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Row {
                        spacing:        ScreenTools.defaultFontPixelWidth * 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        QGCButton {
                            text:           !TyphoonHQuickInterface.copyingFiles ? qsTr("Start") : qsTr("Cancel")
                            width:          ScreenTools.defaultFontPixelWidth  * 16
                            height:         ScreenTools.defaultFontPixelHeight * 2
                            visible:        !_importAction
                            enabled:        !TyphoonHQuickInterface.copyingDone
                            onClicked: {
                                if(TyphoonHQuickInterface.copyingFiles) {
                                    TyphoonHQuickInterface.cancelExportData()
                                } else {
                                    TyphoonHQuickInterface.exportData(exportUTMCheck.checked)
                                }
                            }
                        }
                        QGCButton {
                            text:           qsTr("Close")
                            width:          ScreenTools.defaultFontPixelWidth  * 16
                            enabled:        !TyphoonHQuickInterface.copyingFiles
                            height:         ScreenTools.defaultFontPixelHeight * 2
                            onClicked: {
                                rootLoader.sourceComponent = null
                                mainWindow.enableToolbar()
                            }
                        }
                    }
                }
            }
            Component.onCompleted: {
                TyphoonHQuickInterface.initExport()
                if(_importAction) {
                    TyphoonHQuickInterface.importMission()
                }
                rootLoader.width  = fileCopyDialogItem.width
                rootLoader.height = fileCopyDialogItem.height
            }
        }
    }
    //-- Manual Bind Dialog
    Component {
        id:             bindDialog
        Item {
            id:         bindDialogItem
            width:      mainWindow.width
            height:     mainWindow.height
            z:          1000000
            MouseArea {
                anchors.fill:   parent
                onWheel:        { wheel.accepted = true; }
                onPressed:      { mouse.accepted = true; }
                onReleased:     { mouse.accepted = true; }
            }
            Rectangle {
                id:             bindDialogShadow
                anchors.fill:   bindDialogRect
                radius:         bindDialogRect.radius
                color:          qgcPal.window
                visible:        false
            }
            DropShadow {
                anchors.fill:       bindDialogShadow
                visible:            bindDialogRect.visible
                horizontalOffset:   4
                verticalOffset:     4
                radius:             32.0
                samples:            65
                color:              Qt.rgba(0,0,0,0.75)
                source:             bindDialogShadow
            }
            Rectangle {
                id:     bindDialogRect
                width:  mainWindow.width   * 0.65
                height: bindCol.height * 1.5
                radius: ScreenTools.defaultFontPixelWidth
                color:  qgcPal.alertBackground
                border.color: qgcPal.alertBorder
                border.width: 2
                anchors.centerIn: parent
                Column {
                    id:                 bindCol
                    width:              bindDialogRect.width
                    spacing:            ScreenTools.defaultFontPixelHeight * 3
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    anchors.centerIn:   parent
                    QGCLabel {
                        text:           qsTr("Manual RC Bind")
                        font.family:    ScreenTools.demiboldFontFamily
                        font.pointSize: ScreenTools.largeFontPointSize
                        color:          qgcPal.alertText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    QGCLabel {
                        text:           qsTr("Flip vehicle upside down and select the Bind button")
                        color:          qgcPal.alertText
                        font.family:    ScreenTools.demiboldFontFamily
                        font.pointSize: ScreenTools.mediumFontPointSize
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Row {
                        spacing:        ScreenTools.defaultFontPixelWidth * 4
                        anchors.horizontalCenter: parent.horizontalCenter
                        QGCButton {
                            text:           qsTr("Bind")
                            width:          ScreenTools.defaultFontPixelWidth  * 16
                            height:         ScreenTools.defaultFontPixelHeight * 2
                            onClicked: {
                                TyphoonHQuickInterface.manualBind()
                                rootLoader.sourceComponent = null
                                mainWindow.enableToolbar()
                            }
                        }
                        QGCButton {
                            text:           qsTr("Cancel")
                            width:          ScreenTools.defaultFontPixelWidth  * 16
                            height:         ScreenTools.defaultFontPixelHeight * 2
                            onClicked: {
                                rootLoader.sourceComponent = null
                                mainWindow.enableToolbar()
                            }
                        }
                    }
                }
            }
            Component.onCompleted: {
                rootLoader.width  = bindDialogItem.width
                rootLoader.height = bindDialogItem.height
            }
        }
    }
    //-- Firmware Update
    Component {
        id:             firmwareUpdate
        Item {
            id:         firmwareUpdateItem
            width:      mainWindow.width
            height:     mainWindow.height
            z:          1000000
            MouseArea {
                anchors.fill:   parent
                onWheel:        { wheel.accepted = true; }
                onPressed:      { mouse.accepted = true; }
                onReleased:     { mouse.accepted = true; }
            }
            Rectangle {
                id:             firmwareUpdateShadow
                anchors.fill:   firmwareUpdateRect
                radius:         firmwareUpdateRect.radius
                color:          qgcPal.window
                visible:        false
            }
            DropShadow {
                anchors.fill:       firmwareUpdateShadow
                visible:            firmwareUpdateRect.visible
                horizontalOffset:   4
                verticalOffset:     4
                radius:             32.0
                samples:            65
                color:              Qt.rgba(0,0,0,0.75)
                source:             firmwareUpdateShadow
            }
            Rectangle {
                id:     firmwareUpdateRect
                width:  mainWindow.width * 0.65
                height: fmwUpdCol.height * 1.5
                radius: ScreenTools.defaultFontPixelWidth
                color:  qgcPal.alertBackground
                border.color: qgcPal.alertBorder
                border.width: 2
                anchors.centerIn: parent
                Column {
                    id:                 fmwUpdCol
                    width:              firmwareUpdateRect.width
                    spacing:            ScreenTools.defaultFontPixelHeight * 3
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    anchors.centerIn:   parent
                    QGCLabel {
                        text:           qsTr("Firmware Update")
                        font.family:    ScreenTools.demiboldFontFamily
                        font.pointSize: ScreenTools.largeFontPointSize
                        color:          qgcPal.alertText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    QGCLabel {
                        text:           TyphoonHQuickInterface.updateError
                        visible:        TyphoonHQuickInterface.updateError !== ""
                        color:          qgcPal.alertText
                        font.family:    ScreenTools.demiboldFontFamily
                        font.pointSize: ScreenTools.mediumFontPointSize
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    QGCLabel {
                        text:           qsTr("Do not power off until update is complete.")
                        visible:        TyphoonHQuickInterface.updateError === ""
                        color:          qgcPal.alertText
                        font.family:    ScreenTools.demiboldFontFamily
                        font.pointSize: ScreenTools.mediumFontPointSize
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    ProgressBar {
                        width:          parent.width * 0.75
                        orientation:    Qt.Horizontal
                        minimumValue:   0
                        maximumValue:   100
                        value:          TyphoonHQuickInterface.updateProgress
                        visible:        TyphoonHQuickInterface.updateError === ""
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    QGCButton {
                        text:           qsTr("Close")
                        width:          ScreenTools.defaultFontPixelWidth  * 16
                        height:         ScreenTools.defaultFontPixelHeight * 2
                        visible:        TyphoonHQuickInterface.updateError !== ""
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            rootLoader.sourceComponent = null
                            mainWindow.enableToolbar()
                        }
                    }
                }
            }
            Component.onCompleted: {
                rootLoader.width  = firmwareUpdateItem.width
                rootLoader.height = firmwareUpdateItem.height
            }
        }
    }
    //-- Password Dialog
    Rectangle {
        id:         passwordDialog
        width:      pwdCol.width  * 1.25
        height:     pwdCol.height * 1.25
        radius:     ScreenTools.defaultFontPixelWidth * 0.5
        color:      qgcPal.window
        visible:    false
        border.width:   1
        border.color:   qgcPal.text
        anchors.top:    parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        Keys.onBackPressed: {
            passwordDialog.visible = false
        }
        Column {
            id:         pwdCol
            spacing:    ScreenTools.defaultFontPixelHeight
            anchors.centerIn: parent
            QGCLabel {
                text:   qsTr("Please enter new password (8 to 20 characters)")
                anchors.horizontalCenter: parent.horizontalCenter
            }
            QGCTextField {
                id:         passwordField
                echoMode:   TextInput.Password
                width:      ScreenTools.defaultFontPixelWidth * 24
                focus:      true
                anchors.horizontalCenter: parent.horizontalCenter
            }
            QGCLabel {
                text:   qsTr("Please re-enter password")
                anchors.horizontalCenter: parent.horizontalCenter
            }
            QGCTextField {
                id:         passwordFieldConf
                echoMode:   TextInput.Password
                width:      ScreenTools.defaultFontPixelWidth * 24
                focus:      true
                anchors.horizontalCenter: parent.horizontalCenter
            }
            QGCLabel {
                text:   qsTr("Once set, the connection will be closed.\nRestart the vehicle and reconnect.")
                horizontalAlignment:      Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Row {
                spacing:    ScreenTools.defaultFontPixelWidth * 4
                anchors.horizontalCenter: parent.horizontalCenter
                QGCButton {
                    text:       qsTr("Ok")
                    width:      _buttonWidth
                    enabled:    passwordField.text.length > 7 && passwordField.text.length < 21 && passwordField.text === passwordFieldConf.text
                    onClicked:  {
                        Qt.inputMethod.hide();
                        TyphoonHQuickInterface.setWiFiPassword(passwordField.text)
                        passwordField.text = ""
                        passwordDialog.visible = false
                    }
                }
                QGCButton {
                    text:       qsTr("Cancel")
                    width:      _buttonWidth
                    onClicked:  {
                        Qt.inputMethod.hide();
                        passwordField.text = ""
                        passwordDialog.visible = false
                    }
                }
            }
        }
    }
}