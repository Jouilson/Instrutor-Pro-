INSTRUTOR PRO V11 - PRONTO PARA PUBLICAR

Esta pasta é uma versão web estática do Instrutor Pro V11 conectada ao Supabase informado.

PUBLICAÇÃO PELO CELULAR:
1. Extraia este ZIP.
2. Abra https://app.netlify.com/drop no navegador.
3. Envie a pasta inteira desta pasta (ou arraste a pasta para a área de publicação, quando o navegador permitir).
4. Aguarde a publicação.
5. Abra o endereço .netlify.app fornecido pelo Netlify.

IMPORTANTE:
- A chave sb_publishable_ é apropriada para uso no frontend; não coloque service_role/sb_secret no navegador.
- Depois de abrir o site, crie a conta pela tela Criar conta.
- Em seguida, no Supabase: Authentication > Users, copie o UUID e altere a role na tabela public.profiles.
- O banco ainda precisa ter as tabelas e políticas RLS esperadas pelo aplicativo.
