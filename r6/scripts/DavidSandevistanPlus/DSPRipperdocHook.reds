// DSPRipperdocHook.reds — Adds "Stabilize Sandevistan" button to ripperdoc menu
// Only appears when hovering over our Martinez Sandevistan cyberware.
// On confirm: sets quest fact so CET can trigger VisitedRipper().

// Custom field for popup header override (prefixed to avoid conflict with other mods)
@addField(VendorConfirmationPopupData)
public let dspHeaderText: String;

@wrapMethod(VendorConfirmationPopup)
protected cb func OnInitialize() -> Bool {
    wrappedMethod();
    if !Equals(this.m_data.dspHeaderText, s"") {
        inkTextRef.SetText(this.m_itemNameText, this.m_data.dspHeaderText);
    };
}

@wrapMethod(RipperDocGameController)
private final func SetButtonHintsHover(item: wref<UIInventoryItem>, isVendorItem: Bool) -> Void {
    if IsDefined(item) && Equals(this.m_screen, CyberwareScreenType.Ripperdoc) && this.m_dollSelected {
        let tdbid: TweakDBID = ItemID.GetTDBID(item.GetID());
        if tdbid == t"Items.MartinezSandevistanPlusPlus" && item.IsEquipped() {
            let questsSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_player.GetGame());
            let psychoStage: Int32 = questsSystem.GetFactStr("martinezsandevistan_cyberpsycho") - 10;
            if psychoStage > 0 {
                this.m_buttonHintsController.AddButtonHint(n"unequip_item", "Stabilize Sandevistan");
                wrappedMethod(item, isVendorItem);
                return;
            };
        };
    };
    wrappedMethod(item, isVendorItem);
}

@wrapMethod(RipperDocGameController)
protected cb func OnSlotClick(evt: ref<ItemDisplayClickEvent>) -> Bool {
    let item: wref<UIInventoryItem> = evt.uiInventoryItem;
    if IsDefined(item) && evt.actionName.IsAction(n"unequip_item") && Equals(this.m_screen, CyberwareScreenType.Ripperdoc) {
        let tdbid: TweakDBID = ItemID.GetTDBID(item.GetID());
        if tdbid == t"Items.MartinezSandevistanPlusPlus" && item.IsEquipped() {
            let questsSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_player.GetGame());
            let psychoStage: Int32 = questsSystem.GetFactStr("martinezsandevistan_cyberpsycho") - 10;
            if psychoStage > 0 {
                let stabilizeCost: Int32 = this.DSPGetStabilizeCost(psychoStage);
                if stabilizeCost > this.m_VendorDataManager.GetLocalPlayerCurrencyAmount() {
                    let notification: ref<UIMenuNotificationEvent> = new UIMenuNotificationEvent();
                    notification.m_notificationType = UIMenuNotificationType.VNotEnoughMoney;
                    this.m_uiSystem.QueueEvent(notification);
                    return false;
                };
                this.DSPStabilizeConfirmationPopup(item, stabilizeCost);
                return true;
            };
        };
    };
    return wrappedMethod(evt);
}

@addMethod(RipperDocGameController)
private func DSPGetStabilizeCost(psychoStage: Int32) -> Int32 {
    if psychoStage <= 1 { return 2000; }
    if psychoStage == 2 { return 4000; }
    if psychoStage == 3 { return 7000; }
    if psychoStage == 4 { return 12000; }
    return 20000;
}

@addMethod(RipperDocGameController)
private func DSPStabilizeConfirmationPopup(item: wref<UIInventoryItem>, price: Int32) -> Void {
    this.m_isPurchaseEquip = true;
    this.m_isInEquipPopup = true;
    this.m_audioSystem.Play(n"ui_hacking_access_granted");
    let data: ref<VendorConfirmationPopupData> = new VendorConfirmationPopupData();
    data.notificationName = n"base\\gameplay\\gui\\widgets\\notifications\\vendor_confirmation.inkwidget";
    data.isBlocking = true;
    data.useCursor = true;
    data.queueName = n"modal_popup";
    data.inventoryItem = item;
    data.quantity = 1;
    data.type = VendorConfirmationPopupType.BuyNotEquipableCyberware;
    data.price = price;
    data.dspHeaderText = "Stabilize Sandevistan?";
    this.m_tokenPopup = this.ShowGameNotification(data);
    this.m_tokenPopup.RegisterListener(this, n"OnDSPStabilizePopupClosed");
    this.m_buttonHintsController.Hide();
}

@addMethod(RipperDocGameController)
protected cb func OnDSPStabilizePopupClosed(data: ref<inkGameNotificationData>) -> Bool {
    this.m_tokenPopup = null;
    let resultData: ref<VendorConfirmationPopupCloseData> = data as VendorConfirmationPopupCloseData;
    this.m_isPurchaseEquip = false;
    this.m_isInEquipPopup = false;
    if resultData.confirm {
        let questsSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(this.m_player.GetGame());
        let psychoStage: Int32 = questsSystem.GetFactStr("martinezsandevistan_cyberpsycho") - 10;
        let price: Int32 = this.DSPGetStabilizeCost(psychoStage);

        let transactionSystem: ref<TransactionSystem> = GameInstance.GetTransactionSystem(this.m_player.GetGame());
        transactionSystem.RemoveItem(this.m_player, MarketSystem.Money(), price);
        transactionSystem.GiveItem(this.m_VendorDataManager.GetVendorInstance(), MarketSystem.Money(), price);

        // Signal CET: set quest fact to trigger VisitedRipper
        questsSystem.SetFactStr("dsp_ripper_stabilize", 1);

        this.m_audioSystem.Play(n"ui_gui_cyberware_tab_open");
        this.m_VendorBlackboard.SignalVariant(GetAllBlackboardDefs().UI_Vendor.VendorData);
    } else {
        this.m_hoverArea = gamedataEquipmentArea.Invalid;
        this.AnimateMinigrids();
    };
    this.m_buttonHintsController.Show();
    this.m_audioSystem.Play(n"ui_menu_onpress");
}
