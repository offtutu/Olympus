package olympusmotors.olympus;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

// Aqui são anotações para melhorar o sistema, onde ele tem suas automatizações do projeto e etc...
@SpringBootApplication
@Configuration
@EnableAutoConfiguration
@ComponentScan
public class OlympusApplication {

	public static void main(String[] args) {
		SpringApplication.run(OlympusApplication.class, args);
	}

}
