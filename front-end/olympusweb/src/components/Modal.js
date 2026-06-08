// Esse aqui seria basicamente um widget reutilizavel.
export default function Modal({aberto, titulo, children, aoFechar}) {
  // Se ele não encontrar nenhuum widget aberto ele retorna nadd
  if (!aberto) {
    return null;
  }

  // Aqui basicamente seria o widget
  return (
    <div className="modal-overlay">
      <div className="modal">
        <div className="modal-header">
          <h2>{titulo}</h2>
          <button type="button" className="modal-close" onClick={aoFechar}>
            X
          </button>
        </div>

        {children}
      </div>
    </div>
  );
}
