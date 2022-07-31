const fs = require('fs');
const { REST } = require('@discordjs/rest');
const { clientId, guildId, token } = require('./config.json');

const commands = [];
const commandFiles = fs.readdirSync('./src').filter(file => file.endsWith('.js'));

for (const file of commandFiles) {
  console.log(`Registering ${file}`);
	const command = require(`./src/${file}`);
	commands.push(command.data.toJSON());
}

const rest = new REST({ version: '9' }).setToken(token);

(async () => {
  try {
    await rest.put(
      `/applications/${clientId}/guilds/${guildId}/commands`,
      { body: commands },
      );

      console.log('Successfully registered application commands.');
    } catch (error) {
      console.error(error);
    }
  })();