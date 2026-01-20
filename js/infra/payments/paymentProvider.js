/**
 * Contrato de pagos (scaffold).
 *
 * Idea: el juego no debe acoplarse a Stripe/Google Play/etc.
 * Se usará un PaymentProvider intercambiable.
 */

/**
 * @typedef {Object} PaymentProduct
 * @property {string} id
 * @property {string} title
 * @property {string} [description]
 * @property {string} priceText  - Ej: "4,99 €"
 * @property {number} [priceValue] - Ej: 4.99 (opcional)
 * @property {string} [currency] - Ej: "EUR" (opcional)
 * @property {('consumable'|'non_consumable'|'subscription')} [type]
 */

/**
 * @typedef {Object} PurchaseResult
 * @property {boolean} success
 * @property {string} [productId]
 * @property {string} [transactionId]
 * @property {string} [message]
 * @property {any} [raw] - payload original del proveedor
 */

export class PaymentProvider {
  /**
   * Identificador del provider (p.ej. 'mock', 'stripe', 'googleplay')
   * @returns {string}
   */
  getId() {
    throw new Error('Not implemented');
  }

  /**
   * Lista productos disponibles.
   * @returns {Promise<PaymentProduct[]>}
   */
  async listProducts() {
    throw new Error('Not implemented');
  }

  /**
   * Lanza el flujo de compra de un producto.
   * @param {string} productId
   * @returns {Promise<PurchaseResult>}
   */
  async purchase(productId) {
    throw new Error('Not implemented');
  }

  /**
   * Restaura compras (útil en móvil, o cuando haya cuentas).
   * @returns {Promise<PurchaseResult[]>}
   */
  async restorePurchases() {
    return [];
  }
}

