package olympusmotors.olympus;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import olympusmotors.olympus.modules.Usuario;
import olympusmotors.olympus.modules.UsuarioRepository;
import olympusmotors.olympus.modules.UsuarioRole;
import olympusmotors.olympus.service.TokenService;

@SpringBootTest
@AutoConfigureMockMvc
class OlympusApplicationTests {

	@Autowired
	private MockMvc mockMvc;

	@Autowired
	private TokenService tokenService;

	@Autowired
	private UsuarioRepository usuarioRepository;

	private String adminToken;

	@BeforeEach
	void prepararUsuarioAdmin() {
		Usuario admin = (Usuario) usuarioRepository.findByLogin("admin-teste");

		if (admin == null) {
			admin = usuarioRepository.save(new Usuario("admin-teste", "senha-teste", UsuarioRole.ADMIN));
		}

		adminToken = tokenService.gerarToken(admin);
	}

	// Teste para listar todos os carros
	@Test
	void testeDeListarTodosOCarros() throws Exception {
		mockMvc.perform(get("/api/carros"))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$").isArray());
	}

	// Teste para a criação de carro
	@Test
	void testeParaCriarUmCarro() throws Exception {
		String json = """
				{
					"codigo": 234,
                	"nome": "Civic",
                	"marca": "Honda",
                	"modelo": "Civic EX",
                	"ano": 2000
				}
				""";

		mockMvc.perform(post("/api/carros")
				.header("Authorization", "Bearer " + adminToken)
				.contentType(MediaType.APPLICATION_JSON)
				.content(json))
				.andExpect(status().isCreated())
				.andExpect(jsonPath("$.id").exists())
				.andExpect(jsonPath("$.codigo").value(234))
				.andExpect(jsonPath("$.nome").value("Civic"))
				.andExpect(jsonPath("$.marca").value("Honda"))
				.andExpect(jsonPath("$.modelo").value("Civic EX"))
				.andExpect(jsonPath("$.ano").value(2000));
	}

	// Teste para ver se a exceção de caracteres invalidos está funcionando corretamente
	@Test
	void testeParaRetornarErroQuandoCriacaoDeCarroForInvalida() throws Exception {
		String json = """
				{
					"codigo": 235,
					"nome": "",
					"marca": "Honda",
					"modelo": "Civic EX",
					"ano": 2000
				}
				""";

		mockMvc.perform(post("/api/carros")
				.header("Authorization", "Bearer " + adminToken)
				.contentType(MediaType.APPLICATION_JSON)
				.content(json))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.mensagem", containsString("Nome")))
				.andExpect(jsonPath("$.status").value(400))
				.andExpect(jsonPath("$.timestamp", notNullValue()))
				.andExpect(jsonPath("$.path").value("/api/carros"));
	}

	// Teste para ver se o erro de not found está funcionando
	@Test
	void testeParaRetornarErroQuandoOCarroNaoExiste() throws Exception {
    	mockMvc.perform(get("/api/carros/999"))
            .andExpect(status().isNotFound())
        	.andExpect(jsonPath("$.mensagem").exists());
    }
}
