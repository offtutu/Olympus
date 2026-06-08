package olympusmotors.olympus.modules;

// Aqui serve para representar um conjunto fixo, que no caso seria o "UserRole", que é basicamente os cargos 
public enum UsuarioRole {
    ADMIN("admin"),
    COMUM("comum");

    private final String cargo;

    UsuarioRole(String cargo) {
        this.cargo = cargo;
    }

    // Aqui é um comando que utiliza o metodo getter para pegar o cargo que esse Enum representa e já retorna o cargo.
    public String getCargo() {
        return cargo;
    }
}
