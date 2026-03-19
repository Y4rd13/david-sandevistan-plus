// DSPVendorsXLPatch.reds — Fix VendorsXL workspot animation looping
// VendorsXL creates AISpotNodes but never sets isWorkspotInfinite = true,
// causing complex workspot animations to play once and stop.
// This patch runs after VendorsXL's sector callback and sets the flag.

class DSPVendorsXLPatch extends ScriptableService {

    private cb func OnLoad() {
        GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"OnVendorsXLSector")
            .AddTarget(ResourceTarget.Path(r"base\\vendorsxl\\sectors\\vendorsxl.streamingsector"));
    }

    private cb func OnVendorsXLSector(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
        let i: Int32 = 0;
        // VendorsXL uses pairs: i*2 = entity node, i*2+1 = AISpotNode
        // Max 100 vendors, iterate until we run out of nodes
        while i < 100 {
            let node = sector.GetNode(i * 2 + 1) as worldAISpotNode;
            if !IsDefined(node) {
                break;
            }
            node.isWorkspotInfinite = true;
            i += 1;
        }
    }
}
