import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can register new node",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("nodelink", "register-node", [], wallet_1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    block.receipts[0].result.expectOk();
  },
});

Clarinet.test({
  name: "Can share file",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("nodelink", "register-node", [], wallet_1.address),
      Tx.contractCall("nodelink", "share-file", 
        ["test.txt", "0x1234", types.uint(1000)], 
        wallet_1.address)
    ]);
    
    assertEquals(block.receipts.length, 2);
    block.receipts[1].result.expectOk().toBe("u0");
  },
});

Clarinet.test({
  name: "Can update reputation",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    const wallet_2 = accounts.get("wallet_2")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("nodelink", "register-node", [], wallet_1.address),
      Tx.contractCall("nodelink", "update-reputation", 
        [types.principal(wallet_1.address), types.int(5)], 
        wallet_2.address)
    ]);
    
    assertEquals(block.receipts.length, 2);
    block.receipts[1].result.expectOk();
  },
});
