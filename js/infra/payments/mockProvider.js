import { PaymentProvider } from './paymentProvider.js';

const STORAGE_KEY = 'heroina_payments_mock';

function load() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : { purchases: [] };
  } catch {
    return { purchases: [] };
  }
}

function save(data) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
}

function makeTxId() {
  return `mock_${Date.now()}_${Math.random().toString(16).slice(2)}`;
}

/**
 * Provider mock: simula compras para desarrollo.
 * No valida nada, no cobra nada, solo registra compras en localStorage.
 */
export class MockPaymentProvider extends PaymentProvider {
  constructor(products = []) {
    super();
    this._products = products;
  }

  getId() {
    return 'mock';
  }

  async listProducts() {
    return this._products;
  }

  async purchase(productId) {
    const product = this._products.find((p) => p.id === productId);
    if (!product) {
      return { success: false, productId, message: 'Producto no encontrado (mock)' };
    }

    const data = load();
    const tx = { productId, transactionId: makeTxId(), date: new Date().toISOString() };
    data.purchases.push(tx);
    save(data);

    return { success: true, productId, transactionId: tx.transactionId, message: 'Compra simulada (mock)', raw: tx };
  }

  async restorePurchases() {
    const data = load();
    return data.purchases.map((p) => ({ success: true, productId: p.productId, transactionId: p.transactionId, raw: p }));
  }
}

